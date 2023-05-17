import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';

export default {
    input: './EnforcerFunction/index.ts',
    plugins: [typescript({ module: 'esnext' }), nodeResolve(), commonjs()],
    output: {
        file: './dist/EnforcerFunction/index.js',
        format: 'cjs',
        generatedCode: {
            constBindings: true
        }
    }
}