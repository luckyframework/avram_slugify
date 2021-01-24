require "./spec_helper"

describe AvramSlugify do
  describe ".set" do
    it "does not set anything if slug is already set" do
      op = build_op(slug: "dont-mess-with-me")

      slugify(op.slug, "Software Developer")

      op.slug.value.should eq("dont-mess-with-me")
    end

    it "skips blank slug candidates" do
      op = build_op(job_title: "Software Developer")

      slugify(op.slug, ["", op.first_name, op.job_title])

      op.slug.value.should eq("software-developer")
    end

    describe "with a single slug candidate" do
      it "it sets slug from a single attribute" do
        op = build_op(job_title: "Software Developer")

        slugify(op.slug, op.job_title)

        op.slug.value.should eq("software-developer")
      end

      it "it sets slug from a single string" do
        op = build_op

        slugify(op.slug, "Software Developer")

        op.slug.value.should eq("software-developer")
      end

      it "it sets slug from a single string" do
        op = build_op

        slugify(op.slug, "Software Developer")

        op.slug.value.should eq("software-developer")
      end
    end

    describe "with an array of slug candidates" do
      describe "and there is no other record with the same slug" do
        it "sets using a String" do
          op = build_op

          slugify(op.slug, ["Software Developer"])

          op.slug.value.should eq("software-developer")
        end

        it "sets using an attribute" do
          op = build_op(job_title: "Software Developer")

          slugify(op.slug, [op.job_title])

          op.slug.value.should eq("software-developer")
        end

        it "sets when using multiple attributes" do
          op = build_op(first_name: "James", last_name: "Smith")

          slugify(op.slug, [[op.first_name, op.last_name]])

          op.slug.value.should eq("james-smith")
        end
      end

      describe "and the first slug candidate is not unique" do
        it "chooses the first unique one in the array" do
          UserFactory.create &.slug("james")
          UserFactory.create &.slug("foo")
          op = build_op(first_name: "James", last_name: "Smith")

          slugify(op.slug, [op.first_name, "foo", [op.first_name, op.last_name]])

          op.slug.value.should eq("james-smith")
        end
      end

      describe "and all of the slug candidates are used already" do
        it "uses the first present candidate and appends a UUID" do
          UserFactory.create &.slug("james")
          UserFactory.create &.slug("smith")
          op = build_op(first_name: "James", last_name: "Smith")

          # First string is empty. Added to make sure it is not used with
          # the UUID.
          slugify(op.slug, ["", op.first_name, op.last_name])

          op.slug.value.to_s.should start_with("james-")
          op.slug.value.to_s.split("-", 2).last.size.should eq(UUID.random.to_s.size)
        end
      end

      describe "all slug candidates are blank" do
        it "leaves the slug as nil" do
          op = build_op(first_name: "")

          # First string is empty. Added to make sure it is not used with
          # the UUID.
          slugify(op.slug, ["", op.first_name])

          op.slug.value.should be_nil
        end
      end
    end

    it "uses the query to scope uniqueness check" do
      UserFactory.create &.slug("helen").job_title("A")

      op = build_op(first_name: "Helen")
      slugify(op.slug, op.first_name, UserQuery.new.job_title("B"))
      op.slug.value.should eq("helen")

      op = build_op(first_name: "Helen")
      slugify(op.slug, op.first_name, UserQuery.new.job_title("A"))
      op.slug.value.to_s.should start_with("helen-") # Has UUID appended
    end
  end
end

private def slugify(slug, slug_candidates, query = UserQuery.new)
  AvramSlugify.set(slug, slug_candidates, query)
end

private def build_op(**named_args)
  User::SaveOperation.new(**named_args)
end
