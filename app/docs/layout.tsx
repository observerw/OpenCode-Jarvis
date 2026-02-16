import type { ReactNode } from "react";
import type { Node, Root } from "fumadocs-core/page-tree";
import { DocsLayout } from "fumadocs-ui/layouts/docs";

import { source } from "@/lib/source";

function isHidden(url: string) {
  return url.split("/").some((part) => part.startsWith("_"));
}

function filterNode(node: Node): Node | null {
  if (node.type === "page") {
    return isHidden(node.url) ? null : node;
  }

  if (node.type === "folder") {
    const children = node.children
      .map((item) => filterNode(item))
      .filter((item): item is Node => item !== null);

    const index = node.index && !isHidden(node.index.url) ? node.index : undefined;

    if (!index && children.length === 0) {
      return null;
    }

    return {
      ...node,
      children,
      index,
    };
  }

  return node;
}

function filterTree(tree: Root): Root {
  return {
    ...tree,
    children: tree.children
      .map((item) => filterNode(item))
      .filter((item): item is Node => item !== null),
  };
}

const tree = filterTree(source.pageTree);

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <DocsLayout
      tree={tree}
      nav={{ title: "Wiki" }}
      sidebar={{ defaultOpenLevel: 1 }}
    >
      {children}
    </DocsLayout>
  );
}
