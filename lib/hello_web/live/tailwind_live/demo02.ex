defmodule HelloWeb.TailwindLive.Demo02 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-1/3 py-20 bg-gray-200">
      <h1 class="text-2xl">Container</h1>
      <div class="container mx-auto ">
        <div class="relative bg-white p-10 rounded-lg shadow-lg">
          <div class="absolute top-0 right-0 bg-red-500 text-red-100 rounded py-2 px-4 transform translate-x-2 -translate-y-2 text-xs">
            Brand New
          </div>
          <p>
            Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder chocolate cake biscuit shortbread. Carrot cake brownie powder lemon drops chocolate cake chocolate croissant. Chocolate bar cake wafer sugar plum pie jelly-o donut gummi bears brownie. Caramels apple pie jelly beans candy canes marzipan biscuit chocolate cake jujubes. Pudding biscuit gummi bears gummies gummi bears lemon drops. Gummi bears lemon drops macaroon jelly marshmallow gummies macaroon cotton candy. Pastry icing sweet roll chupa chups candy muffin dessert pudding. Carrot cake jelly beans lollipop jelly beans jelly macaroon tootsie roll caramels sugar plum.
          </p>
        </div>
      </div>
    </div>

    <div class="h-1/3 bg-blue-200 p-4 lg:p-20">
      <h1>Desktop vs mobile</h1>
      <div class="lg:flex md:space-x-8">
        <div class="bg-white p-10 mt-10 md:w-1/2">on mobile we stack</div>
        <div class="bg-white p-10 mt-10 md:w-1/2">on desktop, we are side by side</div>
      </div>
    </div>

    <div class="bg-green-700 h-64 flex justify-center items-center">
      <h1 class="text-4xl text-green-100">Centered!</h1>
    </div>

    <div class="bg-gray-300 p-10 flex justify-between">
      <div>logo</div>
      <div>navigation</div>
    </div>
    """
  end
end
