import type { Metadata } from "next";
import "./globals.css";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
export const metadata: Metadata = { title: { default: "ASAM — Afghan Students Association in Malaysia", template: "%s · ASAM" }, description: "A platform for Afghan students in Malaysia to connect, learn and support one another.", metadataBase: new URL("https://asam.my"), openGraph: { title: "ASAM — Afghan Students Association in Malaysia", description: "Connecting Afghan students across Malaysia.", type: "website" } };
export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) { return <html lang="en" data-scroll-behavior="smooth"><body><SiteHeader/><main>{children}</main><SiteFooter/></body></html>; }
