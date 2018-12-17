defmodule PusherWeb.Router do
  use PusherWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PusherWeb do
    pipe_through :api
  end
end
