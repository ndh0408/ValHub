import type { Metadata, Viewport } from 'next';
import localFont from 'next/font/local';
import './globals.css';

const vietnam = localFont({
  src: [
    { path: '../assets/fonts/BeVietnamPro-Regular.ttf', weight: '400' },
    { path: '../assets/fonts/BeVietnamPro-Medium.ttf', weight: '500' },
    { path: '../assets/fonts/BeVietnamPro-SemiBold.ttf', weight: '600' },
    { path: '../assets/fonts/BeVietnamPro-Bold.ttf', weight: '700' },
  ],
  variable: '--font-body',
  display: 'swap',
});
export const metadata: Metadata = {
  title: 'ValVN · Bản xem trước mobile',
  description: 'Bản demo giao diện mobile ValVN: Trang chủ, Cửa hàng, Cộng đồng, Bộ sưu tập và Hồ sơ. Dữ liệu minh họa, không kết nối tài khoản Riot.',
  robots: { index: false, follow: false },
};
export const viewport: Viewport = { width: 'device-width', initialScale: 1, themeColor: '#f4f4f7' };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="vi"><body className={vietnam.variable}>{children}</body></html>;
}
