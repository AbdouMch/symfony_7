<?php

$excludedDirectories = [
    'vendor',
    'node_modules',
    'docker',
    'public',
    'var',
];
$finder = (new PhpCsFixer\Finder())
    ->in(__DIR__)
    ->exclude($excludedDirectories)
;

return (new PhpCsFixer\Config())
    ->setRules([
        '@Symfony' => true,
        'ordered_class_elements' => true,
    ])
    ->setFinder($finder)
;
