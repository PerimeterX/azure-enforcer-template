import {nodeResolve} from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';
import json from '@rollup/plugin-json';

export default {
    input: './EnforcerFunction/index.ts',
    plugins: [
        nodeResolve({preferBuiltins: true}),
        typescript({module: 'esnext'}),
        json(),
        commonjs(),
    ],
    output: [
        {
            file: './dist/EnforcerFunction/index.js',
            format: 'cjs',
            generatedCode: {
                constBindings: true
            }
        },
        {
            file: './EnforcerFunction/index.js',
            format: 'esm',
            generatedCode: {
                constBindings: true
            }
        }
    ]
}