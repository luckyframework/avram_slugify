# AvramSlugify

AvramSlugify generates slugs for database columns. These slugs can be used for
creating nice looking URLs and permalinks.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     avram_slugify:
       github: luckyframework/avram_slugify
       version: ~> 0.1
   ```

2. Run `shards install`

## Require the shard

### With Lucky projects

Require the shard in your `src/shards.cr` file after requiring Avram:

```crystal
# After requiring Avram...
require "avram_slugify"
```
### With other Crystal projects

Require the shard after Avram:

```crystal
# After requiring Avram...
require "avram_slugify"
```

## Usage

Let's say you have an `Article` model with 2 `String` columns, `slug` and
`title`. You can use `AvramSlugify.set` to set the `slug` column to a slugified
version of the `title`.

```crystal
class SaveArticle < Article::SaveOperation
  before_save do
    AvramSlugify.set slug,
      using: title,
      query: ArticleQuery.new
  end
end
```

1. The first argument is the attribute you want to store the generated slug
   on. In this case `slug`, but it could be any String attribute.
1. The second argument is called a **slug candidate**. In this case `title`
   is the slug candidate.
1. The third argument is the query to use when checking for slug uniqueness.

So if the value of the slug candidate `title` is `"Avram is a great ORM"`, the
`slug` value will be set to `avram-is-a-great-orm`.

### What if the generated slug is not unique?

If the slug is not unique, a `UUID` will be appended to the first slug
candidate (the attribute passed to `using`).

So if an `Article` has a slug with `hello-world` and then you try to save a *new*
Article with a `title` set to `"Hello World"`, the slug will not be unique. To
make the slug unique `AvramSlugify` will append a `UUID` to the slug.
For example: `hello-world-3fa569f5-6678-4f77-a281-fb1b9d850407`

### Using multiple slug candidates

To make it less likely that `AvramSlugify` will have to append a `UUID`, you can
provide multiple slug candidates in `using`.

For example, you could do `using: [title, author_email]`. If the generated
slug from `title` is already taken, AvramSlugify will try to generate a slug
from `author_email`. If that doesn't work it will append a UUID to `title`

### Scoping uniqueness check

Let's say an `Article` belongs to an `Account` and you want slugs to be unique per
account. Here's how you'd do that:

```crystal
class SaveArticle < Article::SaveOperation
  # This means you will need to pass in an account when saving/updating
  # https://luckyframework.org/guides/database/validating-saving#passing-extra-data-to-operations
  needs account : Account

  before_save do
    AvramSlugify.set slug.
      using: title,
      # Use the Account to query against Articles in the same Account
      query: ArticleQuery.new.account_id(@account.id)
  end
end
```

### Combining multiple attributes for a slug

Let's say you have a `User` with a `invite_code` that you'd like to be generated
from the `first_name` and `last_name`.

You can give an array of attributes and they will be combined when generating
the slug:

```crystal
AvramSlugify.set invite_code,
  using: [[first_name, last_name]],
  query: UserQuery.new
```

So if `first_name` is `"Jane"` and `last_name` is `"Adler"`, the generated
slug for `invite_code` will be `"jane-adler"`.

> You must put the array in another array. If you did just
> `[first_name, last_name]` AvramSlugify would use `first_name` by default and
> `last_name` if the `first_name` is not unique

You can also use multiple slug candidates for fallbacks by adding more slug
candidates to the array passed to `using`:

```
[
  nickname,
  [first_name, last_name],
  [first_name, last_name, location]
]
```

### Using strings as slug candidates

Occassionally you may want to use a string as a slug candidate:

```crystal
using: ["first-#{first_name.value}"]
```

### What if the slug candidate is blank?

`Avram::Attribute`s can be nil or empty strings so if the slug candidate's
value is nil or an empty string the slug value will be unchanged.

### What if the slug is already set?

`AvramSlugify` will not overwrite an existing slug.

If you want to reset a slug, first set the slug value to `nil`, then run
`AvramSlugify.set`:

```crystal
slug.value = nil
AvramSlugify.set slug,
  using: title,
  query: ArticleQuery.new
```

## Contributing

1. Fork it (<https://github.com/luckyframework/avram_slugify/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul Smith](https://github.com/paulcsmith) - creator and maintainer
