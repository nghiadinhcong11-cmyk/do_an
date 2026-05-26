import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      onwarn(warning, warn) {
        const isSignalrPureAnnotationWarning =
          warning.code === 'INVALID_ANNOTATION' &&
          typeof warning.id === 'string' &&
          warning.id.includes('@microsoft/signalr')

        if (isSignalrPureAnnotationWarning) {
          return
        }

        warn(warning)
      },
    },
  },
})
