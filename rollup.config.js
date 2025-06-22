import {nodeResolve} from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';
import json from '@rollup/plugin-json';

export default {
    input: './src/index.ts',
    plugins: [
        nodeResolve({preferBuiltins: true}),
        typescript({module: 'esnext'}),
        json(),
        commonjs(),
    ],
    output: [
        {
            file: './EnforcerFunction/index.js',
            format: 'module',
            generatedCode: {
                preferConst: true
            },
        }
    ]
}