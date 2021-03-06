defmodule Ecto.Repo.Transaction do
  @moduledoc false

  @dialyzer {:no_opaque, transaction: 3}

  def transaction(name, fun, opts) when is_function(fun, 0) do
    {adapter, _, meta} = Ecto.Repo.Registry.lookup(name)
    adapter.transaction(meta, opts, fun)
  end

  def transaction(name, %Ecto.Multi{} = multi, opts) do
    {adapter, _, meta} = Ecto.Repo.Registry.lookup(name)
    wrap = &adapter.transaction(meta, opts, &1)
    return = &adapter.rollback(meta, &1)

    case Ecto.Multi.__apply__(multi, name, wrap, return) do
      {:ok, values} -> {:ok, values}
      {:error, {key, error_value, values}} -> {:error, key, error_value, values}
    end
  end

  def in_transaction?(name) do
    {adapter, _, meta} = Ecto.Repo.Registry.lookup(name)
    adapter.in_transaction?(meta)
  end

  def rollback(name, value) do
    {adapter, _, meta} = Ecto.Repo.Registry.lookup(name)
    adapter.rollback(meta, value)
  end
end
