import { VerifyCredential } from "@/components/verify-credential";
export default async function VerifyCertificate({params}:{params:Promise<{token:string}>}){const {token}=await params;return <VerifyCredential kind="certificate" key={token}/>}
