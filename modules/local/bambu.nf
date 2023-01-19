process BAMBU {
    label 'process_medium'

    conda     (params.enable_conda ? "conda-forge::r-base=4.0.3 bioconda::bioconductor-bambu=3.0.6 bioconda::bioconductor-bsgenome=1.62.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-bambu:3.0.6--r42hc247a5b_0' :
        'quay.io/biocontainers/bioconductor-bambu:3.0.6--r42hc247a5b_0' }"

    input:
    tuple path(fasta), path(gtf)
    path bams

    output:
    path "counts_gene.txt"          , emit: ch_gene_counts
    path "counts_transcript.txt"    , emit: ch_transcript_counts
    path "extended_annotations.gtf" , emit: extended_gtf
    path "versions.yml"             , emit: versions

    script:
    """
    run_bambu.r \\
        --tag=. \\
        --ncore=$task.cpus \\
        --annotation=$gtf \\
        --fasta=$fasta $bams

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        bioconductor-bambu: \$(Rscript -e "library(bambu); cat(as.character(packageVersion('bambu')))")
        bioconductor-bsgenome: \$(Rscript -e "library(BSgenome); cat(as.character(packageVersion('BSgenome')))")
    END_VERSIONS
    """
}