require "avram"
require "cadmium_transliterator"
require "uuid"

module AvramSlugify
  VERSION = "0.1.0"
  extend self

  alias SluggableAttribute = Avram::Attribute(String?)
  alias SlugCandidate = String | SluggableAttribute | Array(SluggableAttribute | String | Array(SluggableAttribute))

  # :nodoc:
  # This method is a shortcut method allowing you to use just a SluggableAttribute
  # or String without wrapping it in an array.
  def set(slug : SluggableAttribute,
          using slug_candidate : SluggableAttribute | String,
          query : Avram::Queryable) : Nil
    set(slug, [slug_candidate], query)
  end

  def set(slug : Avram::Attribute(String?),
          using slug_candidates : Array(String | SluggableAttribute | Array(SluggableAttribute)),
          query : Avram::Queryable) : Nil
    if slug.value.blank?
      slug_candidates = slug_candidates.map do |candidate|
        parameterize(candidate)
      end.reject(&.blank?)

      slug_candidates.each do |candidate|
        next if query.clone.where(slug.name, candidate).first?
        slug.value = candidate
      end
    end

    if slug.value.blank? && (candidate = slug_candidates.first?)
      slug.value = "#{candidate}-#{UUID.random}"
    end
  end

  private def parameterize(value : String) : String
    Cadmium::Transliterator.parameterize(value)
  end

  private def parameterize(value : SluggableAttribute) : String
    parameterize(value.value.to_s)
  end

  private def parameterize(values : Array(SluggableAttribute)) : String
    values.map do |value|
      parameterize(value)
    end.join("-")
  end
end
