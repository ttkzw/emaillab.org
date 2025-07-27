import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: "emaillab.org",
			social: [
				{
					icon: "github",
					label: "GitHub",
					href: "https://github.com/withastro/starlight",
				},
			],
			sidebar: [
				{
					label: "DJB's software maniacs",
					items: [
						{
							label: "DJB's software maniacs (qmail 関連情報)",
							link: "/djb/",
						},
						{
							label: "qmailとPOP",
							badge: "Obsolete",
							autogenerate: { directory: "/djb/qmail-pop/" },
							collapsed: true,
						},
						{
							label: "qmailとIMAP",
							badge: "Obsolete",
							autogenerate: { directory: "/djb/qmail-imap/" },
							collapsed: true,
						},
						{
							label: "qmailとパッチ",
							badge: "Obsolete",
							autogenerate: { directory: "/djb/qmail-patch/" },
							collapsed: true,
						},
						{
							label: "qmapop",
							link: "/djb/qmapop/",
							badge: "Obsolete",
						},
						{
							label: "qmail-vida",
							link: "/djb/qmail-vida/",
							badge: "Obsolete",
						},
						{
							label: "qmailanalog",
							badge: "Obsolete",
							autogenerate: { directory: "/djb/qmailanalog/" },
							collapsed: true,
						},
						{
							label: "tcpserverの勧め",
							autogenerate: { directory: "/djb/tcpserver/" },
							collapsed: true,
						},
						{
							label: "daemontoolsの勧め",
							autogenerate: { directory: "/djb/daemontools/" },
							collapsed: true,
						},
						{
							label: "更新履歴",
							link: "/djb/history/",
						},
					],
				},
				{
					label: "Mutt",
					autogenerate: { directory: "/mutt/" },
					collapsed: true,
					badge: "Obsolete",
				},
				{
					label: "SpamAssassin",
					link: "/spamassassin/",
				},
				{
					label: "MUAs for Windows - Windows のメイラーの評価 -",
					collapsed: true,
					badge: "Obsolete",
					items: [
						{
							label: "MUAs for Windows - Windows のメイラーの評価 -",
							link: "/win-mailer/",
						},
						{
							label: "はじめに",
							link: "/win-mailer/first/",
						},
						{
							label: "試験環境",
							link: "/win-mailer/server/",
						},
						{
							label: "選定基準",
							link: "/win-mailer/criterion/",
						},
						{
							label: "選定したメイラ─",
							link: "/win-mailer/selected/",
						},
						{
							label: "調査結果",
							collapsed: true,
							items: [
								{
									label: "表1. 基礎情報",
									link: "/win-mailer/table-basic/",
								},
								{
									label: "表2. へッダ",
									link: "/win-mailer/table-header/",
								},
								{
									label: "表3. 日本語処理",
									link: "/win-mailer/table-japanese/",
								},
								{
									label: "表4. 言語",
									link: "/win-mailer/table-lang/",
								},
								{
									label: "表5. 暗号",
									link: "/win-mailer/table-cipher/",
								},
								{
									label: "表6. SMTP, POP, IMAP, LDAP",
									link: "/win-mailer/table-otherspec/",
								},
							],
						},
						{
							label: "解説",
							collapsed: true,
							items: [
								{
									label: "表1. 基礎情報",
									link: "/win-mailer/exp-basic/",
								},
								{
									label: "表2. へッダ",
									link: "/win-mailer/exp-header/",
								},
								{
									label: "表3. 日本語処理",
									link: "/win-mailer/exp-japanese/",
								},
								{
									label: "表4. 言語",
									link: "/win-mailer/exp-lang/",
								},
								{
									label: "表5. 暗号",
									link: "/win-mailer/exp-cipher/",
								},
								{
									label: "表6. SMTP, POP, IMAP, LDAP",
									link: "/win-mailer/exp-otherspec/",
								},
							],
						},
						{
							label: "更新履歴",
							link: "/win-mailer/history/",
						},
					],
				},
				{
					label: "インターネットメールに関すること",
					autogenerate: { directory: "/essay/" },
					collapsed: true,
				},
				{
					label: "Java Mailer T42 Project",
					badge: "Obsolete",
					autogenerate: { directory: "/t42/" },
					collapsed: true,
				},
			],
		}),
	],
});
