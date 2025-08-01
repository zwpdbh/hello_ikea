defmodule HelloWeb.TailwindLive.Demo03 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-20 bg-green-200 text-green-800 grid grid-cols-3 gap-2">
      <div class="bg-green-100 rounded p-5">card 1</div>
      <div class="bg-green-100 rounded p-5">card 2</div>
      <div class="bg-green-100 rounded p-5">card 3</div>
      <div class="bg-green-100 rounded p-5">card 4</div>
      <div class="bg-green-100 rounded p-5">card 5</div>
      <div class="bg-green-100 rounded p-5">card 6</div>
    </div>
    <div class="p-20 bg-teal-200 text-teal-800 grid grid-cols-3 gap-3 grid-rows-6">
      <div class="bg-teal-100 rounded p-5">card 1</div>
      <div class="bg-teal-100 rounded p-5 row-span-2 col-span-2">card 2</div>
      <div class="bg-teal-100 rounded p-5">card 3</div>
      <div class="bg-teal-100 rounded p-5 row-span-2">card 4</div>
      <div class="bg-teal-100 rounded p-5 row-span-2">card 5</div>
      <div class="bg-teal-100 rounded p-5">card 6</div>
    </div>
    <div class="p-20 bg-orange-200 text-orange-800 grid grid-cols-4 gap-2 grid-rows-3">
      <div class="bg-orange-100 p-5 rounded row-span-3">image</div>
      <div class="bg-orange-100 p-5 rounded col-span-2 row-span-2 flex items-center justify-center">
        content
      </div>
      <div class="bg-orange-100 p-5 rounded">something</div>
      <div class="bg-orange-100 p-5 rounded  col-start-2 col-span-3">footer</div>
    </div>
    """
  end
end
