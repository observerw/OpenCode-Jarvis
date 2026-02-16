import Link from "next/link";

export default function HomePage() {
  return (
    <main
      style={{
        minHeight: "100vh",
        display: "grid",
        placeItems: "center",
      }}
    >
      <Link href="/docs">Open Wiki</Link>
    </main>
  );
}
