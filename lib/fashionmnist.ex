defmodule AxonDatasets.FashionMNIST do
  alias AxonDatasets.Utils

  @default_data_path "tmp/fashionmnist"
  @base_url 'http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/'
  @image_file 'train-images-idx3-ubyte.gz'
  @label_file 'train-labels-idx1-ubyte.gz'

  defp download_images(opts \\ []) do
    data_path = opts[:data_path] || @default_data_path
    transform = opts[:transform_images] || fn out -> out end

    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      Utils.unzip_cache_or_download(@base_url, @image_file, data_path, unzip: true)

    transform.({images, {:u, 8}, {n_images, n_rows, n_cols}})
  end

  defp download_labels(opts \\ []) do
    data_path = opts[:data_path] || @default_data_path
    transform = opts[:transform_images] || fn out -> out end

    <<_::32, n_labels::32, labels::binary>> =
      Utils.unzip_cache_or_download(@base_url, @label_file, data_path, unzip: true)

    transform.({labels, {:u, 8}, {n_labels}})
  end

  def download(opts \\ []),
    do: {download_images(opts), download_labels(opts)}
end
