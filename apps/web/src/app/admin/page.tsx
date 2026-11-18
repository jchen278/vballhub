import { Suspense } from "react";
import { redirect } from "next/navigation";
import { auth0, AUTH0_ROLES_CLAIM } from "@/lib/auth0";
import { prisma } from "@/lib/prisma";

async function AdminContent() {
  const session = await auth0.getSession();

  if (!session?.user) {
    redirect("/auth/login?returnTo=/admin");
  }

  const rawRoles = (session.user as Record<string, unknown>)[AUTH0_ROLES_CLAIM];
  const roles =
    Array.isArray(rawRoles) && rawRoles.every((role) => typeof role === "string")
      ? rawRoles
      : [];

  if (!roles.includes("vballhub:admin")) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-background px-4 py-12">
        <section className="w-full max-w-xl space-y-5 rounded-3xl border bg-card p-6 shadow-sm sm:p-8">
          <div>
            <p className="text-sm font-semibold uppercase tracking-wider text-destructive">
              Access check failed
            </p>
            <h1 className="mt-2 text-3xl font-bold text-foreground">
              Admin role not found in this session
            </h1>
            <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
              You are signed in, but this app did not receive the{" "}
              <code>vballhub:admin</code> role in the configured roles claim in
              the Auth0 ID token.
            </p>
          </div>

          <div className="rounded-xl bg-muted p-4 text-sm">
            <p className="font-semibold text-foreground">
              Roles received by the app
            </p>
            <p className="mt-1 text-muted-foreground">
              {roles.length ? roles.join(", ") : "No roles claim received"}
            </p>
          </div>

          <p className="text-sm leading-relaxed text-muted-foreground">
            Auth0 role assignments are added to the ID token by the deployed Post
            Login Action. After confirming that Action is attached to the Login
            flow, sign out and sign in again so Auth0 can issue a fresh token with
            the current roles.
          </p>

          <div className="flex flex-wrap gap-3">
            <a
              href="/auth/logout?returnTo=%2Fadmin"
              className="inline-flex h-11 items-center justify-center rounded-full bg-primary px-5 text-sm font-semibold text-primary-foreground hover:bg-primary/90"
            >
              Sign out and try again
            </a>
            <a
              href="/"
              className="inline-flex h-11 items-center justify-center rounded-full border px-5 text-sm font-semibold text-foreground hover:bg-muted"
            >
              Go home
            </a>
          </div>
        </section>
      </main>
    );
  }

  const pendingSubmissions = await prisma.submission.findMany({
    where: { status: "pending" },
    include: { venue: true },
    orderBy: { createdAt: "asc" },
  });

  return (
    <main className="mx-auto max-w-5xl px-4 py-10">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">vballHub Admin Queue</h1>
          <p className="text-sm text-muted-foreground">
            Signed in as {session.user.email ?? session.user.name}
          </p>
        </div>
        <a
          href="/auth/logout"
          className="inline-flex h-10 items-center justify-center rounded-full border px-4 text-sm font-semibold hover:bg-muted"
        >
          Sign out
        </a>
      </div>

      <section className="mt-8 space-y-4">
        <h2 className="text-lg font-semibold">
          Pending Submissions ({pendingSubmissions.length})
        </h2>
        {pendingSubmissions.length === 0 ? (
          <p className="rounded-xl border p-6 text-sm text-muted-foreground">
            No pending event submissions right now.
          </p>
        ) : (
          <pre className="overflow-x-auto rounded-xl bg-muted p-4 text-xs">
            {JSON.stringify(pendingSubmissions, null, 2)}
          </pre>
        )}
      </section>
    </main>
  );
}

export default function AdminPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center bg-background">
          <p className="animate-pulse text-sm text-muted-foreground">
            Loading admin dashboard...
          </p>
        </div>
      }
    >
      <AdminContent />
    </Suspense>
  );
}