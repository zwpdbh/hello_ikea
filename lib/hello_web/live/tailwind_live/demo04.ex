defmodule HelloWeb.TailwindLive.Demo04 do
  use HelloWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-20 bg-white grid grid-cols-6 gap-4 text-gray-800">
      <div class="divide-y divide-gray-300">
        <div>
          <div class="text-3xl font-bold">Wei Zhao</div>
          <div class="mb-8">hyperion_z@outlook.com</div>
          <div>
            Fullstack developer who use Elixir to find myself.
          </div>
        </div>
        <div class="space-y-4">
          <div class="text-2xl font-bold">About</div>
          <div>
            <div class="font-sm">Main Skill Stack</div>
            <div class="font-bold">Elixir, Rust, JavaScript, Azure, AWS</div>
          </div>
          <div>
            <div class="font-sm">Telephone</div>
            <div class="font-bold">(+086)15811257483</div>
          </div>
        </div>
      </div>
      <div class="col-start-2 col-span-5 space-y-2">
        <div class="container max-auto">
          <div class="relative bg-white p-7 shadow-lg rounded">
            <div class="absolute top-0 left-0 text-lg font-bold rounded px-4 py-1 transform -translate-x-2 -translate-y-2">
              Current Status
            </div>
            <div>
              Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder
            </div>
          </div>
        </div>
        <div class="container max-auto">
          <div class="relative bg-white p-7 shadow-lg rounded">
            <div class="absolute top-0 left-0 text-lg font-bold rounded px-4 py-1 transform -translate-x-2 -translate-y-2">
              Project Experimence
            </div>
            <div class="space-y-5">
              <div>
                <div class="transform -translate-x-4 flex items-center divide-x divide-gray-300">
                  <div class="font-semibold pr-3">Azure Container Storage Test</div>
                  <div class="flex pl-3 space-x-3">
                    <div class="text-sm font-medium italic">Microsft</div>
                    <div class="text-sm font-light">2021 -- 2025</div>
                  </div>
                </div>
                <div>
                  Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder
                </div>
              </div>

              <div>
                <div class="transform -translate-x-4 flex items-center divide-x divide-gray-300">
                  <div class="font-semibold pr-3">Azure Container Storage Test</div>
                  <div class="flex pl-3 space-x-3">
                    <div class="text-sm font-medium italic">Microsft</div>
                    <div class="text-sm font-light">2021 -- 2025</div>
                  </div>
                </div>
                <div>
                  Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="container max-auto">
          <div class="relative bg-white p-7 shadow-lg rounded">
            <div class="absolute top-0 left-0 text-lg font-bold rounded px-4 py-1 transform -translate-x-2 -translate-y-2">
              Education
            </div>
            <div class="space-y-2">
              <div class="flex items-center divide-x divide-gray-300">
                <div class="font-semibold pr-3">University of Otago</div>
                <div class="flex pl-3 space-x-3">
                  <div class="text-sm font-medium italic">Computer Science, MASc</div>
                  <div class="text-sm font-light">2016 - 2018</div>
                </div>
              </div>
              <div class="flex items-center divide-x divide-gray-300">
                <div class="font-semibold pr-3">Beijing University and Technology</div>
                <div class="flex pl-3 space-x-3">
                  <div class="text-sm font-medium italic">Computer Science, BS</div>
                  <div class="text-sm font-light">2004 - 2009</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
