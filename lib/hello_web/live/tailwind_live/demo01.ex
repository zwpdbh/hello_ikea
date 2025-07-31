defmodule HelloWeb.TailwindLive.Demo01 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-20">
      <h2 class="mb-4">Spacing Section</h2>
      <p class="mb-4">Tailwind helps us space things out with margin and padding.</p>

      <button class="mr-3 py-2 px-4">Learn more</button>
      <button class="py-2 px-4">Sign up</button>
    </div>

    <div class="p-20 bg-blue-200">
      <h2 class="mb-4">Box Properties</h2>
      <p>Box properties includes: background, border, rounding, shadow</p>
      <div class="p-10 bg-purple-400 rounded-lg border-purple-500 border shadow-lg">I am a box</div>
    </div>

    <div class="py-20 px-10 bg-orange-300">
      <h2>Sizing and numbering</h2>

      <div>
        <p>unit times 4 will be the value of pixels on screen</p>
        <button class="p-4 bg-green-400 rounded w-8">click me</button>
        <button class="p-4 bg-green-400 rounded w-12">click me</button>
        <button class="p-4 bg-green-400 rounded w-20">click me</button>
        <button class="p-4 bg-green-400 rounded w-32">click me</button>
        <button class="p-4 bg-green-400 rounded w-48 h-48">click me</button>
      </div>
    </div>

    <div class="p-20 text-gray-800 leading-relaxed">
      <h2 class="mb-2 text-4xl text-gray-700 font-bold tracking-wide">Typography</h2>
      <h3 class="mb-10 text-2xl text-gray-500">Learning tailwind is more fun than I expect</h3>

      <p class="mb-8 ">
        Cupcake ipsum dolor sit amet jujubes chocolate bar. Cupcake gummi bears biscuit chocolate cake caramels biscuit gingerbread soufflé cake. Sugar plum gummies marzipan bonbon halvah pudding jelly beans shortbread ice cream. Sweet muffin apple pie cake jelly croissant. Pie biscuit lemon drops gummies chocolate bar croissant. Biscuit marzipan pudding lollipop gummi bears muffin fruitcake pie.
      </p>

      <p class="mb-8">
        Dragée pudding ice cream wafer jelly beans ice cream carrot cake soufflé. Dragée tiramisu chocolate sugar plum oat cake jelly candy bear claw halvah. Chocolate cake marshmallow sugar plum cake tootsie roll lollipop shortbread. Icing jelly beans brownie toffee chocolate cake. Jelly beans brownie dessert fruitcake lemon drops pudding toffee sweet roll. Jelly beans gummies bonbon dessert fruitcake gummi bears fruitcake dessert. Cake tart jelly pastry bear claw lemon drops. Soufflé wafer powder fruitcake topping gingerbread. Cake pudding sweet sugar plum pastry. Cotton candy tart candy soufflé marshmallow oat cake.
      </p>
      <p class="mb-8">
        Tiramisu tart croissant soufflé danish tootsie roll candy apple pie. Bear claw brownie sweet roll chupa chups jelly beans cupcake shortbread chocolate. Candy bonbon sugar plum marzipan lemon drops cake. Chocolate fruitcake cake soufflé ice cream cheesecake chocolate bar marshmallow. Sesame snaps wafer oat cake candy cake jelly-o. Gummies wafer sweet roll toffee pastry. Soufflé marshmallow sesame snaps apple pie jelly-o tootsie roll.
      </p>
    </div>

    <div class="p-20 bg-gray-800 border-gray-900 rounded-lg space-y-2">
      <h2 class="text-gray-200">Color</h2>
      <div class="p-4 rounded-lg bg-red-100 text-red-800 hover:text-red-100 hover:bg-red-800 hover:translate-x-10 transform transition duration-300">
        I am a box
      </div>
      <div class="p-4 rounded-lg bg-red-200 text-red-700  hover:translate-x-10 duration-300 ">
        I am a box
      </div>
      <div class="p-4 rounded-lg bg-red-300 text-red-600">I am a box</div>
      <div class="p-4 rounded-lg bg-red-400 text-red-500">I am a box</div>
      <div class="p-4 rounded-lg bg-red-500 text-red-400">I am a box</div>
      <div class="p-4 rounded-lg bg-red-600 text-red-300">I am a box</div>
      <div class="p-4 rounded-lg bg-red-700 text-red-200">I am a box</div>
      <div class="p-4 rounded-lg bg-red-800 text-red-100">I am a box</div>
      <div>
        <h1 class="text-6xl font-bold text-gray-800 bg-gradient-to-br from-blue-400 to-purple-400">
          Whoa Gradients
        </h1>

        <h1 class="text-6xl font-bold text-transparent bg-clip-text bg-gradient-to-br from-blue-400 to-purple-400">
          Whoa Gradients
        </h1>
      </div>
    </div>
    """
  end
end
