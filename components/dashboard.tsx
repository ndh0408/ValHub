'use client';

import { ArrowUpRight, ChevronRight, Clock3, Crown, Radar, Shield, Sparkles, Trophy, Users, Zap } from 'lucide-react';

export function SectionTitle({ children, action, onClick }: { children: React.ReactNode; action?: string; onClick?: () => void }) {
  return <div className="section-title"><h2>{children}</h2>{action && <button onClick={onClick}>{action}<ChevronRight size={14} /></button>}</div>;
}

export function RankCard() {
  return <section className="card rank-card" aria-label="Xếp hạng minh họa"><div className="card-top"><span className="eyebrow"><Trophy size={14} /> XẾP HẠNG CỦA BẠN</span><span className="subtle">Mùa hiện tại</span></div><div className="rank-main"><div className="rank-emblem"><Shield size={35} strokeWidth={1.6} /><span>III</span></div><div className="rank-info"><h3>Kim cương 3</h3><p>72 <span>/ 100 RR</span><b><ArrowUpRight size={12} /> 18 RR</b></p></div></div><div className="progress"><span style={{ width: '72%' }} /></div><div className="rank-footer"><span>Còn 28 RR để lên Bất tử</span><span>72%</span></div></section>;
}

export function HomeDashboard({ navigate, details }: { navigate: (tab: number) => void; details: (title: string) => void }) {
  return <>
    <div className="greeting"><div><p>Chào buổi tối,</p><h2>Sẵn sàng leo rank?</h2></div><span className="status"><i />Máy chủ ổn định</span></div>
    <button className="hero" onClick={() => details('Trận gần nhất')} aria-label="Xem chi tiết trận gần nhất"><img src="/images/tactical-city.png" alt="Thành phố chiến thuật với các tòa tháp lúc hoàng hôn" /><div className="hero-shade" /><div className="hero-content"><span className="hero-tag"><Radar size={12} /> TRẬN GẦN NHẤT</span><div className="hero-title"><div><h2>Ascent</h2><p>Đấu xếp hạng · 32 phút</p></div><div className="score">13<span> : </span>8</div></div><div className="hero-bottom"><span className="victory">CHIẾN THẮNG</span><span>Xem trận đấu <ArrowUpRight size={15} /></span></div></div></button>
    <RankCard />
    <SectionTitle action="Xem tất cả" onClick={() => navigate(1)}>Dành cho bạn</SectionTitle>
    <div className="quick-grid"><button className="card quick-card" onClick={() => navigate(1)}><span className="icon-tile coral"><Sparkles size={20} /></span><h3>Cửa hàng hôm nay</h3><p>4 vật phẩm mới</p><span className="quick-bottom"><Clock3 size={12} /> 08:42:16<ChevronRight size={14} /></span></button><button className="card quick-card" onClick={() => details('Battle Pass')}><span className="icon-tile violet"><Crown size={20} /></span><h3>Battle Pass</h3><p>Cấp 38 / 50</p><div className="progress"><span style={{ width: '76%' }} /></div><span className="quick-bottom">Còn 12 cấp<ChevronRight size={14} /></span></button></div>
    <SectionTitle action="Cộng đồng" onClick={() => navigate(2)}>Cùng nhau chiến thắng</SectionTitle><button className="card team-card" onClick={() => navigate(2)}><span className="icon-tile mint"><Users size={22} /></span><div><h3>Tìm đồng đội hợp ý</h3><p>Kết nối. Lập đội. Leo rank.</p></div><ChevronRight size={18} /></button>
    <SectionTitle>Lịch sử gần đây</SectionTitle><div className="card history"><Match map="Haven" score="13 – 10" result="Thắng" rr="+21" /><Match map="Bind" score="9 – 13" result="Thua" rr="−16" loss /></div>
    <div className="end-note"><Zap size={13} /> Một nơi cho mọi thứ VALORANT.</div>
  </>;
}

function Match({ map, score, result, rr, loss = false }: { map: string; score: string; result: string; rr: string; loss?: boolean }) {
  return <div className={`match ${loss ? 'loss' : ''}`}><span className="match-icon"><Shield size={20} /></span><div><h3>{map}</h3><p>Đấu xếp hạng · {result}</p></div><div className="match-result"><b>{score}</b><span>{rr} RR</span></div></div>;
}
