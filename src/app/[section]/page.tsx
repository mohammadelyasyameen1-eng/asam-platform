import type { Metadata } from "next";
import Link from "next/link";
import {notFound} from "next/navigation";
import { ArrowRight, Search, UsersRound, CalendarDays, Newspaper, MapPin, ShieldCheck, BookOpen, Sparkles } from "lucide-react";

const pages:Record<string,{title:string;intro:string;icon:typeof UsersRound;items:string[];action?:string}>={
 membership:{title:"Find your place in the community.",intro:"Connect with fellow students, take part in community activities and help shape a shared space for Afghan students in Malaysia.",icon:UsersRound,items:["Connection","Community events","Student resources"]},
 about:{title:"A community, connected.",intro:"ASAM brings Afghan students in Malaysia together around connection, support and shared opportunity. This platform is being prepared for the community, with official organizational information to be added by ASAM.",icon:Sparkles,items:["Mission & vision","What ASAM does","Our community","Organizational structure"]},
 leadership:{title:"Meet the people behind ASAM.",intro:"Leadership information will be published here once confirmed by the association.",icon:UsersRound,items:["Executive Committee","Advisors","Committee Members"]},
 chapters:{title:"A community across campuses.",intro:"Explore university chapters and local coordinators as verified information becomes available.",icon:MapPin,items:["University chapters","Local coordinators","Chapter updates"]},
 universities:{title:"Find your campus community.",intro:"University and chapter listings will be published as ASAM confirms its network information.",icon:MapPin,items:["Browse universities","Filter by state","Connect with chapters"]},
 events:{title:"Good things happen together.",intro:"Upcoming ASAM events will be listed here when the association publishes confirmed details.",icon:CalendarDays,items:["Academic","Cultural","Networking","Community"]},
 news:{title:"News from the community.",intro:"Announcements and updates will be shared here by ASAM administrators.",icon:Newspaper,items:["Announcements","Community stories","Important updates"]},
 gallery:{title:"A glimpse of our community.",intro:"Photos and media will appear here when ASAM publishes approved gallery content.",icon:Sparkles,items:["Community moments","Events","Campus life"]},
 resources:{title:"Helpful resources for your journey.",intro:"A growing library of practical information for Afghan students in Malaysia.",icon:BookOpen,items:["Student resources","Guides & information","Useful links"]},
 contact:{title:"We’d love to hear from you.",intro:"ASAM contact details will be added here once confirmed. For now, use the membership page to learn about joining.",icon:UsersRound,items:["General enquiries","Membership questions","Chapter information"],action:"Explore membership"},
 verify:{title:"Verify an ASAM credential.",intro:"Check an ASAM member ID or certificate using its unique verification code. Only limited verification information is shown.",icon:ShieldCheck,items:["Member ID verification","Certificate verification"]}
};
const heroImages:Record<string,{src:string;alt:string;caption:string}>={
 about:{src:"/images/landmarks/31.jpg",alt:"Afghan mountain cliffs beside vivid blue water",caption:"Afghanistan · Landscape"},
 leadership:{src:"/images/landmarks/33.jpg",alt:"Afghan presidential palace at Barg, with Afghan flags",caption:"Barg · Afghanistan"},
 chapters:{src:"/images/landmarks/34.jpg",alt:"Restored Darul Aman Palace in Kabul",caption:"Darul Aman Palace · Kabul"},
 universities:{src:"/images/landmarks/09.jpg",alt:"A university and city scene",caption:"Learning across borders"},
 events:{src:"/images/landmarks/08.jpg",alt:"A landmark selected for ASAM community events",caption:"Coming together"},
 news:{src:"/images/landmarks/35.jpg",alt:"An Afghan student connecting online",caption:"Stories from the community"},
 membership:{src:"/images/landmarks/36.avif",alt:"Students sharing a welcoming community moment",caption:"Find your community"},
 contact:{src:"/images/landmarks/37.avif",alt:"A welcoming scene selected for contacting ASAM",caption:"Stay connected"},
 gallery:{src:"/images/landmarks/13.jpg",alt:"A cultural landmark from the ASAM photo collection",caption:"Community moments"},
 resources:{src:"/images/landmarks/10.jpg",alt:"A city landmark from the ASAM photo collection",caption:"Helpful resources"},
 verify:{src:"/images/landmarks/16.jpg",alt:"An Afghan landmark from the ASAM photo collection",caption:"Trusted credentials"},
 privacy:{src:"/images/landmarks/14.jpg",alt:"A cultural landmark in Malaysia",caption:"Malaysia · Heritage"},
 terms:{src:"/images/landmarks/19.jpg",alt:"A historic landscape from the ASAM photo collection",caption:"Built on trust"},
 credits:{src:"/images/landmarks/21.jpg",alt:"An Afghan cultural landmark",caption:"Photo credits"}
};
export function generateMetadata({params}:{params:Promise<{section:string}>}):Promise<Metadata>{return params.then(({section})=>({title:pages[section]?.title??"ASAM"}));}

export default async function DirectoryPage({params}:{params:Promise<{section:string}>}){
 const {section}=await params;const data=pages[section];if(!data)notFound();
 const Icon=data.icon;const heroImage=heroImages[section];
 return <><section className={heroImage ? "page-hero has-hero-photo" : "page-hero"} data-landmark={section}>
  <div className="container page-hero-layout">
    <div className="page-hero-inner">
      <div className="page-icon"><Icon size={21}/></div>
      <span className="eyebrow">Afghan Students Association in Malaysia</span>
      <h1>{data.title}</h1>
      <p>{data.intro}</p>
      {["events","news","chapters","universities"].includes(section)&&<label className="directory-search"><Search size={17}/><input aria-label={`Search ${section}`} placeholder={`Search ${section}...`}/><span>⌘ K</span></label>}
    </div>
    {heroImage&&<figure className="page-hero-photo"><img src={heroImage.src} alt={heroImage.alt} loading="eager"/><figcaption>{heroImage.caption}</figcaption></figure>}
  </div>
</section>
 <section className="directory-section"><div className="container"><div className="directory-header"><div><span className="eyebrow">{section==="events"?"Discover & take part":"Explore ASAM"}</span><h2>{section==="events"?"Upcoming events":"Explore the community"}</h2></div><span className="content-state"><i/> Official information will be added by ASAM</span></div>
 {section==="membership"?<div className="membership-layout"><div className="membership-main card"><span className="eyebrow">Membership</span><h2>Find your place in the community.</h2><p>Connect with fellow students, take part in community activities and help shape a shared space for Afghan students in Malaysia.</p><ul><li>Build meaningful connections</li><li>Take part in events and activities</li><li>Access a growing set of student resources</li><li>Contribute your ideas and experience</li></ul><Link className="button button-dark" href="/apply">Start your application <ArrowRight size={16}/></Link><p className="fine-print">Membership categories and eligibility are configurable and will be confirmed by ASAM.</p></div><aside className="membership-aside"><div className="membership-aside-icon"><ShieldCheck/></div><h3>Designed around your privacy</h3><p>Personal information is collected only as needed to support your membership application and is handled through a secure member system.</p><Link href="/privacy">Read the privacy notice <ArrowRight size={14}/></Link></aside></div>
 :section==="verify"?<div className="verify-options"><Link href="/verify/member" className="verify-option card"><ShieldCheck/><h3>Member ID</h3><p>Check whether an ASAM digital member ID is active.</p><span>Verify a member ID <ArrowRight size={14}/></span></Link><Link href="/certificates/verify" className="verify-option card"><BookOpen/><h3>Certificate</h3><p>Check whether an ASAM certificate is valid.</p><span>Verify a certificate <ArrowRight size={14}/></span></Link></div>
 :<div className="directory-empty card"><div className="empty-icon"><Icon size={25}/></div><h3>Nothing published just yet</h3><p>ASAM’s verified {section} information will appear here. Check back soon for updates.</p><div className="empty-pills">{data.items.map(t=><span key={t}>{t}</span>)}</div></div>}
 {data.action&&<p className="directory-bottom"><Link className="inline-link" href="/membership">{data.action} <ArrowRight size={15}/></Link></p>}</div></section><section className="bottom-cta"><div className="container bottom-cta-inner"><div><span className="eyebrow">Be part of the community</span><h2>There’s a place for you here.</h2></div><Link className="button button-dark" href="/membership">Explore membership <ArrowRight size={16}/></Link></div></section></>;
}
