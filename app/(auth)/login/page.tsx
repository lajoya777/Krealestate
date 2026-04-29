import LoginForm from "./login-form";

type SearchParams = Promise<{ redirectTo?: string }>;

export default async function LoginPage({ searchParams }: { searchParams: SearchParams }) {
  const { redirectTo } = await searchParams;
  return <LoginForm redirectTo={redirectTo} />;
}
