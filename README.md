# AxonDatasets

## Usage

We currently support MNIST, FashionMNIST, and CIFAR10 training datasets.

Download or fetch datasets locally like:

```elixir
{train_images, train_labels} = AxonDatasets.MNIST.download()

# Unpack train_images like...
{images_binary, tensor_type, shape} = train_images
```

You can also pass transform functions to `download/1`:

```elixir
transform_images = fn {binary, type, shape} ->
  binary
  |> Nx.from_binary(type)
  |> Nx.reshape(shape)
  |> Nx.divide(255)
  |> Nx.to_batched_list(32)
end

{train_images, train_labels} =
  AxonDatasets.MNIST.download(transform_images: transform_images)

# Transform labels as well, e.g. get one-hot encoding
transform_labels = fn {labels_binary, type, _} ->
  labels_binary
  |> Nx.from_binary(type)
  |> Nx.new_axis(-1)
  |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
  |> Nx.to_batched_list(32)
end

{images, labels} =
  AxonDatasets.MNIST.download(
    transform_images: transform_images,
    transform_labels: transform_labels
  )

```

## Installation

```elixir
def deps do
  [
    {:axon_datasets, "~> 0.1.0-dev", github: "t-rutten/axon_datasets", branch: "main", override: true}
  ]
end
```
