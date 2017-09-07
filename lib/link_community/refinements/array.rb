# frozen_string_literal: true

module ArrayRefinement
  refine Array do
    def ^(other)
      (self - other) | (other - self)
    end
  end
end
