defmodule MicroblogWeb.MessageController do
  use MicroblogWeb, :controller

  alias Microblog.Micro_blogging
  alias Microblog.Micro_blogging.Message

def index(conn, _params) do
    messages = Enum.reverse(Micro_blogging.list_messages())
    render(conn, "index.html", messages: messages)
  end

def new(conn, _params) do
    changeset = Micro_blogging.change_message(%Message{})
    render(conn, "new.html", changeset: changeset)
  end

 def create(conn, %{"message" => message_params}) do
    case Micro_blogging.create_message(message_params) do
      {:ok, message} ->
        MicroblogWeb.Endpoint.broadcast("updates:all", "new_message",
        %{"message_content" => message.content,
          "message_show" => message_path(conn, :show, message)})
        conn
        |> put_flash(:info, "Message created successfully.")
        |> redirect(to: message_path(conn, :show, message))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
end

  def show(conn, %{"id" => id}) do
    message = Micro_blogging.get_message!(id)
    render(conn, "show.html", message: message)
    render(conn, "show.html", liked: Micro_blogging.get_like_by_ids(conn.assigns[:current_user], message), message: message)
  end

  def edit(conn, %{"id" => id}) do
    message = Micro_blogging.get_message!(id)
    changeset = Micro_blogging.change_message(message)
    render(conn, "edit.html", message: message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Micro_blogging.get_message!(id)

    case Micro_blogging.update_message(message, message_params) do
      {:ok, message} ->
        conn
        |> put_flash(:info, "Message updated successfully.")
        |> redirect(to: message_path(conn, :show, message))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", message: message, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Micro_blogging.get_message!(id)
    {:ok, _message} = Micro_blogging.delete_message(message)

    conn
    |> put_flash(:info, "Message deleted successfully.")
    |> redirect(to: message_path(conn, :index))
  end
end
