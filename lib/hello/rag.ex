defmodule Hello.Rag do
  use Ash.Domain

  resources do
    resource Hello.Rag.Section do
      define :create_section, action: :create
      define :search_section, action: :search_section
    end
  end
end
