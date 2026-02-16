import { notFound } from "next/navigation";
import Link from "next/link";
import defaultMdxComponents from "fumadocs-ui/mdx";
import { DocsBody, DocsDescription, DocsPage, DocsTitle } from "fumadocs-ui/page";

import { source } from "@/lib/source";

type PageProps = {
  params: Promise<{
    slug?: string[];
  }>;
};

export default async function DocsPageRoute({ params }: PageProps) {
  const { slug = [] } = await params;

  if (slug.some((part) => part.startsWith("_"))) {
    notFound();
  }

  if (slug.length === 0) {
    const pages = source
      .getPages()
      .filter((item) => !item.slugs.some((part) => part.startsWith("_")));

    return (
      <DocsPage className="wiki-index-page">
        <DocsTitle>Wiki</DocsTitle>
        <DocsDescription>Available articles</DocsDescription>
        <DocsBody>
          <ul>
            {pages.map((item) => (
              <li key={item.url}>
                <Link href={item.url}>{item.data.title ?? item.url}</Link>
              </li>
            ))}
          </ul>
        </DocsBody>
      </DocsPage>
    );
  }

  const page = source.getPage(slug);

  if (!page) {
    notFound();
  }

  const MDXContent = page.data.body;

  return (
    <DocsPage toc={page.data.toc} className="wiki-article-page">
      <DocsBody>
        <MDXContent components={defaultMdxComponents} />
      </DocsBody>
    </DocsPage>
  );
}

export function generateStaticParams() {
  return [
    { slug: [] as string[] },
    ...source
      .generateParams()
      .filter((item) => !item.slug.some((part) => part.startsWith("_"))),
  ];
}

export const dynamic = "force-static";
export const dynamicParams = false;
