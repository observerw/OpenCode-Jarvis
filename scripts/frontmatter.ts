import { resolve } from "node:path";
import { parseFrontmatter } from "@stacksjs/ts-md";

const [, , filePath] = process.argv;

if (!filePath) {
	process.exit(1);
}

try {
	const absPath = resolve(filePath);
	const content = await Bun.file(absPath).text();
	const { data } = parseFrontmatter<Record<string, unknown>>(content);
	console.log(JSON.stringify(data, null, 2));
} catch (error) {
	const msg = error instanceof Error ? error.message : String(error);
	console.error(`Failed to parse frontmatter: ${msg}`);
	process.exit(1);
}
