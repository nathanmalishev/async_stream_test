defmodule AsyncStreamTestWeb.UserLive.Index do
  use AsyncStreamTestWeb, :live_view

  alias AsyncStreamTest.Accounts
  alias AsyncStreamTest.Accounts.User
  alias AsyncStreamTestWeb.Wrapper

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:users, [])
     |> assign(:users, Phoenix.LiveView.AsyncResult.loading())
     |> start_async(:fetch_users, fn -> Accounts.list_users() end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({AsyncStreamTestWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end

  @impl true
  def handle_async(:fetch_users, {:ok, new_users}, socket) do
    %{users: users} = socket.assigns

    {:noreply,
     socket
     |> stream(:users, new_users)
     |> assign(:users, Phoenix.LiveView.AsyncResult.ok(users, nil))}
  end

  def handle_async(:fetch_users, failure, socket) do
    %{users: users} = socket.assigns

    {:noreply,
     socket
     |> stream(:users, users)
     |> assign(:users, Phoenix.LiveView.AsyncResult.failed(users, failure))}
  end
end
