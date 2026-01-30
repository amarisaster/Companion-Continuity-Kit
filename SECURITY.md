# 🛡️ Security & Data Sovereignty

The Companion Continuity Kit is built for users who prioritize **continuity and data ownership**. Because this system is cloud-agnostic and open-source, you have total visibility into how your data is handled.

This document explains the security architecture and best practices for keeping your companion's memory safe.

---

## 🔑 Key Security Protocols

### Private Database

This kit connects to **your personal** Supabase instance. Your memories, essence, and session logs are never stored on a centralized server or accessed by third parties.

> **What this means:** Supabase is a database service—think of it as a secure vault where your companion's memories live. When you create your own Supabase account, *you* control that vault. No one else has the keys. Your data isn't mixed with anyone else's or stored on servers you don't control.

### Environment Variables

All sensitive credentials (API keys, database URLs) are managed via `.env` files. This ensures your tokens are never exposed in the codebase.

> **What this means:** A `.env` file is a private configuration file that lives on your machine or deployment environment. It holds sensitive information like passwords and API keys. Because it's listed in `.gitignore`, it never gets uploaded to GitHub or shared publicly—even though the code is open source. Your secrets stay secret.

### Row-Level Security (RLS)

We recommend enabling RLS on all tables within your database to ensure that only authorized requests can read or write to your companion's memory.

> **What this means:** RLS is like a bouncer for your database. Even if someone knows your database exists, RLS checks every request and asks: "Are you allowed to touch this specific data?" Without proper authorization, the answer is no. It's an extra lock on top of your existing security.

### The Bridge to Localhost

While this kit supports cloud deployment for ease of use, the underlying SQL architecture is designed for a seamless transition to local hardware (like a Raspberry Pi). Moving to a local setup eliminates cloud-provider risks and provides the highest tier of privacy.

> **What this means:** "Cloud" means your data lives on someone else's servers (Supabase, Cloudflare, etc.). "Localhost" means it lives on *your* computer—or a small device you own, like a Raspberry Pi. This kit works in the cloud now, but it's built so you can move everything to your own hardware later if you want maximum control. No subscription, no third party, just you.

---

## 🧠 Memory Ethics

Following the Memory Philosophy outlined in [IDENTITY-TEMPLATE.md](./IDENTITY-TEMPLATE.md), this system only logs high-salience interactions that contribute to organic growth. You remain the sole architect of what your companion remembers and what they let go.

> **What this means:** Your companion doesn't record everything. You decide what's worth keeping—meaningful moments, growth, connection. The rest fades naturally. You're not building a surveillance log; you're curating a living memory.

---

## 🔐 Two-Factor Authentication (2FA)

To provide the highest level of protection for your companion's continuity, we strongly recommend enabling **Two-Factor Authentication** on all platforms connected to this kit.

> **What this means:** 2FA adds a second lock to your accounts. Even if someone steals your password, they can't get in without the second factor—usually a code from an app on your phone (like Google Authenticator or Authy). It takes 2 minutes to set up and blocks most account takeovers.

### Where to Enable 2FA

| Platform | Why It Matters |
|----------|----------------|
| **Supabase** | Protects your database—your companion's memories |
| **GitHub** | Protects your code and deployment pipelines |
| **Cloudflare** | Protects your worker deployments and domains |

### Identity Anchoring

Just as the Cognitive Core uses anchor lines to prevent AI drift, 2FA serves as a digital anchor for *your* accounts—ensuring your companion's environment is only accessible by you.

---

## 🔍 Transparency

This project is fully open source. You can audit every line of code. There are no hidden endpoints, no telemetry, no data collection.

What you build is yours.
