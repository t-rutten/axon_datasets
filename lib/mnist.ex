defmodule AxonDatasets.MNIST do
  alias AxonDatasets.Utils

  @default_data_path "tmp/mnist"
  @base_url 'https://storage.googleapis.com/cvdf-datasets/mnist/'
  @image_file 'train-images-idx3-ubyte.gz'
  @label_file 'train-labels-idx1-ubyte.gz'

  defp download_images(opts) do
    data_path = opts[:data_path] || @default_data_path
    transform = opts[:transform_images] || fn out -> out end

    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      Utils.unzip_cache_or_download(@base_url, @image_file, data_path)

    transform.({images, {:u, 8}, {n_images, n_rows, n_cols}})
  end

  defp download_labels(opts) do
    data_path = opts[:data_path] || @default_data_path
    transform = opts[:transform_labels] || fn out -> out end

    <<_::32, n_labels::32, labels::binary>> =
      Utils.unzip_cache_or_download(@base_url, @label_file, data_path)

    transform.({labels, {:u, 8}, {n_labels}})
  end

  def download(opts \\ []),
    do: {download_images(opts), download_labels(opts)}
end
