import { defineConfig, defineDocs, frontmatterSchema, metaSchema } from "fumadocs-mdx/config";

export const docs = defineDocs({
  dir: "wiki",
  docs: {
    schema: frontmatterSchema,
  },
  meta: {
    schema: metaSchema,
  },
});

export default defineConfig({});
