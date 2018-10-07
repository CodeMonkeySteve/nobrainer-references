require 'no_brainer/document/association/eager_loader'

module NoBrainer::Document::References
  # adapted from NoBrainer::Document::Association::EagerLoader
  def self.eager_load(docs, field_name, field=nil, criteria=nil)
    return  if docs.blank?

    field_name = field_name.to_sym
    field ||= docs.first.root_class.fields[field_name]
    ref_type = field_type = field[:type]
    if (field_type <= Array) && field_type.respond_to?(:object_type) && (field_type.object_type <= NoBrainer::Reference)
      ref_type = field_type.object_type
    end
    raise TypeError, "#{ref_type} is not a NoBrainer::Reference"  unless ref_type <= NoBrainer::Reference
    model_type = ref_type.model_type

    refs = docs.flat_map { |doc|  doc.read_attribute(field_name) }
    refs.compact!
    refs.reject!(&:__hasobj__)

    if refs.present?
      target_key = model_type.table_config.primary_key.to_sym
      ref_ids = refs.map(&:id).uniq

      query = model_type.without_ordering
      query = query.merge(criteria)  if criteria
      targets = query.where(target_key.in => ref_ids).group_by(&target_key)
      refs.each do |ref|
        if (target = targets[ref.id]&.first)
          ref.__setobj__(target)
        end
      end
      refs.uniq!
    end

    docs.select { |doc| Array(doc.read_attribute(field_name)).all?(&:__hasobj__) }
  end

  module AssociationExt
    def eager_load_association(docs, association_name, criteria=nil)
      if (field = docs&.first) && (field = field.root_class.fields[association_name.to_sym]) && field_is_reference_type?(field)
        NoBrainer::Document::References.eager_load(docs, association_name, field, criteria)
      else
        super
      end
    end

  private

    def field_is_reference_type?(field)
      field && (type = field[:type]) && (
        (type <= NoBrainer::Reference) ||
        (type <= Array && type.respond_to?(:object_type) && (type.object_type <= NoBrainer::Reference))
      )
    end

    NoBrainer::Document::Association::EagerLoader.extend(self)
  end
end
