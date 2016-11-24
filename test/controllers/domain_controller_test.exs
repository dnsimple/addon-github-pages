defmodule GithubPagesConnector.DomainControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Services.Accounts
  @dnsimple GithubPagesConnector.DnsimpleDummy

  setup do
    @dnsimple.reset

    {:ok, account} = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    conn           = assign(build_conn, :current_account_id, account.dnsimple_account_id)
    {:ok, conn: conn, account: account}
  end

  describe ".index" do
    test "returns the account's domains in DNSimple", %{conn: conn} do
      @dnsimple.stub(:list_all_domains, {:ok, [%Dnsimple.Domain{name: "domain1.com"}, %Dnsimple.Domain{name: "domain2.com"}]})

      response = get(conn, domain_path(conn, :index)) |> json_response(200)

      assert response == %{"domains" => ~w(domain1.com domain2.com)}
    end
  end

end
