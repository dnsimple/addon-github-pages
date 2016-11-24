defmodule GithubPagesConnector.RepositoryControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Services.Accounts
  @github GithubPagesConnector.GithubDummy

  setup do
    @github.reset

    {:ok, account} = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    conn           = assign(build_conn, :current_account_id, account.dnsimple_account_id)
    {:ok, conn: conn, account: account}
  end

  describe ".index" do
    test "returns the account's GitHub pages repositories", %{conn: conn} do
      @github.stub(:list_all_repositories, {:ok, [%{"name" => "one.github.io"}, %{"name" => "two.github.io"}]})

      response = get(conn, repository_path(conn, :index)) |> json_response(200)

      assert response == %{"repositories" => ~w(one.github.io two.github.io)}
    end
  end

end
