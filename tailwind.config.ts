import type { Config } from "tailwindcss";
export default { content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"], theme: { extend: { colors: { ink: "#07111f", red: "#b91c2b", jade: "#16835b" }, fontFamily: { sans: ["var(--font-geist-sans)", "Arial", "sans-serif"] } } }, plugins: [] } satisfies Config;
