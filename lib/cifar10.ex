defmodule AxonData.CIFAR10 do
  alias AxonData.Utils

  @default_data_path "tmp/cifar10"
  @base_url 'https://www.cs.toronto.edu/~kriz/'
  @dataset_file 'cifar-10-binary.tar.gz'

  defp parse_images(content) do
    for <<example::size(3073)-binary <- content>>, reduce: {<<>>, <<>>} do
      {images, labels} ->
        <<label::size(8)-bitstring, image::size(3072)-binary>> = example

        {images <> image, labels <> label}
    end
  end

  def download(opts \\ []) do
    data_path = opts[:data_path] || @default_data_path
    transform_images = opts[:transform_images] || fn out -> out end
    transform_labels = opts[:transform_labels] || fn out -> out end

    gz = Utils.unzip_cache_or_download(@base_url, @dataset_file, data_path)

    with {:ok, files} <- :erl_tar.extract({:binary, gz}, [:memory, :compressed]) do
      {imgs, labels} =
        files
        |> Enum.filter(fn {fname, _} -> String.match?(List.to_string(fname), ~r/data_batch/) end)
        |> Enum.map(fn {_, content} -> Task.async(fn -> parse_images(content) end) end)
        |> Enum.map(&Task.await(&1, :infinity))
        |> Enum.reduce({<<>>, <<>>}, fn {image, label}, {image_acc, label_acc} ->
          {image_acc <> image, label_acc <> label}
        end)

      {transform_images.({imgs, {:u, 8}, {50000, 3, 32, 32}}),
       transform_labels.({labels, {:u, 8}, {50000}})}
    end
  end
end
