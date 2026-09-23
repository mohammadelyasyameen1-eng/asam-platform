import type { MetadataRoute } from "next";
export default function sitemap():MetadataRoute.Sitemap{const base="https://asam.my";return ["","about","leadership","chapters","universities","events","news","gallery","membership","contact","resources","verify"].map(path=>({url:`${base}/${path}`,lastModified:new Date(),changeFrequency:"monthly",priority:path===""?1:.6}))}
