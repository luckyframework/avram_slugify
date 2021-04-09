require "avram"
require "cadmium_transliterator"
require "uuid"

# Set an `Avram::Atribute` to a slugified version of another attribute or `String`.
#
# See the [README](https://github.com/luckyframework/avram_slugify) for guides.
module AvramSlugify
  VERSION = "0.1.2"
  extend self

  # See the [README](https://github.com/luckyframework/avram_slugify) for guides.
  def set(slug : Avram::Attribute(String?),
          using slug_candidate : Avram::Attribute(String?) | String,
          query : Avram::Queryable) : Nil
    set(slug, [slug_candidate], query)
  end

  # See the [README](https://github.com/luckyframework/avram_slugify) for guides.
  def set(slug : Avram::Attribute(String?),
          using slug_candidates : Array(String | Avram::Attribute(String?) | Array(Avram::Attribute(String?))),
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

  private def parameterize(value : Avram::Attribute(String?)) : String
    parameterize(value.value.to_s)
  end

  private def parameterize(values : Array(Avram::Attribute(String?))) : String
    values.map do |value|
      parameterize(value)
    end.join("-")
  end
end
