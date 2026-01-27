import typescript from 'rollup-plugin-typescript2'
import resolve from '@rollup/plugin-node-resolve'

export default {
  input: 'src/index.ts',
  output: [
    {
      dir: 'dist',
      format: 'esm',
      sourcemap: true
    },
    {
      dir: 'dist/cjs',
      format: 'cjs',
      sourcemap: true
    }
  ],
  plugins: [
    resolve(),
    typescript({
      clean: true,
      useTsconfigDeclarationDir: true
    })
  ],
  external: [
    '@capacitor/core'
  ]
}
