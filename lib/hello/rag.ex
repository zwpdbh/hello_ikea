defmodule Hello.Rag do
  use Ash.Domain

  resources do
    resource Hello.Rag.Section do
      define :create_section, action: :create
    end
  end
end
