import type { Metadata } from "next";
import type { ReactNode } from "react";
import { RootProvider } from "fumadocs-ui/provider/next";

import "./globals.css";

export const metadata: Metadata = {
  title: "Wiki",
  description: "Project wiki powered by Fumadocs",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: ReactNode;
}>) {
  return (
    <html lang="zh-CN" suppressHydrationWarning>
      <body>
        <RootProvider>{children}</RootProvider>
      </body>
    </html>
  );
}
