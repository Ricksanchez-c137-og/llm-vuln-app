import type React from "react"
import Link from "next/link"

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-black text-white">
      <nav className="bg-gray-900 p-4">
        <div className="container mx-auto flex justify-between items-center">
          <Link href="/" className="text-xl font-bold">
            Hosn Chat
          </Link>
          <ul className="flex space-x-4">
            <li>
              <Link href="/" className="hover:text-gray-300">
                Home
              </Link>
            </li>
            <li>
              <Link href="/about" className="hover:text-gray-300">
                About
              </Link>
            </li>
          </ul>
        </div>
      </nav>
      <main className="container mx-auto py-8">{children}</main>
      <footer className="bg-gray-900 p-4 text-center">
        <p>&copy; Hosn Chat. All rights reserved.</p>
      </footer>
    </div>
  )
}