import { NextResponse, type NextRequest } from "next/server";
import { auth0, AUTH0_ROLES_CLAIM } from "./lib/auth0";

export async function proxy(request: NextRequest) {
  const authResponse = await auth0.middleware(request);

  if (request.nextUrl.pathname.startsWith("/admin")) {
    const session = await auth0.getSession(request);
    if (!session) {
      const loginUrl = new URL("/auth/login", request.url);
      loginUrl.searchParams.set("returnTo", request.nextUrl.pathname);
      return NextResponse.redirect(loginUrl);
    }

    const roles = (session.user as Record<string, unknown>)[AUTH0_ROLES_CLAIM];
    if (!Array.isArray(roles) || !roles.includes("vballhub:admin")) {
      return NextResponse.redirect(new URL("/", request.url));
    }
  }

  return authResponse;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt).*)",
  ],
};