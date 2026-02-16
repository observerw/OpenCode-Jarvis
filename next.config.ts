import type { NextConfig } from "next";
import { createMDX } from "fumadocs-mdx/next";

const withMDX = createMDX();
const basePath = process.env.NEXT_PUBLIC_BASE_PATH;

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  assetPrefix: basePath,
};

export default withMDX(nextConfig);
