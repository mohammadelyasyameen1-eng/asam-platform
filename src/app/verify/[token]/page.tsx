import { VerifyCredential } from "@/components/verify-credential";
export default async function VerifyMember({params}:{params:Promise<{token:string}>}){const {token}=await params;return <VerifyCredential kind="member" key={token}/>}
