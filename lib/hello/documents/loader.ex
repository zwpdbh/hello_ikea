defmodule Hello.Documents.Loader do
  require Logger

  @documents_path "/home/zw/code/elixir_programming/hello/documents"

  def load() do
    load_files_from_folder(@documents_path)
    |> Enum.filter(fn each_file -> file_with_extensions?(each_file, [".md", ".livemd"]) end)
    |> Enum.reduce([], fn each_file, acc ->
      contents =
        File.stream!(each_file, 8192)
        |> Stream.map(&String.trim/1)
        |> Enum.to_list()

      contents ++ acc
    end)
    |> Enum.take(2)
  end

  def load_files_from_folder(folder_path) do
    case File.ls(folder_path) do
      {:ok, files} ->
        files_or_folders =
          files
          |> Enum.map(fn each_file -> Path.join([folder_path, each_file]) end)
          |> Enum.group_by(fn abs_path -> File.dir?(abs_path) end)

        case files_or_folders do
          %{false: plain_files, true: folders} ->
            Enum.reduce(folders, plain_files, fn each_folder, acc ->
              acc ++ load_files_from_folder(each_folder)
            end)

          %{false: plain_files} ->
            plain_files
        end

      _ ->
        []
    end
  end

  def file_with_extensions?(file, extension_list) when is_list(extension_list) do
    String.downcase(Path.extname(file)) in Enum.map(extension_list, &String.downcase/1)
  end
end
