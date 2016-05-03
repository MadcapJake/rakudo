class CompUnit::DependencySpecification {
    has Str:D $.short-name         is required;
    has Int:D $.source-line-number = 0;
    has Str:D $.from = 'Perl6';
    has $.version-matcher = True;
    has $.auth-matcher = True;
    has $.api-matcher = True;

    method Str(CompUnit::DependencySpecification:D:) {
        join '', $.short-name,
          ($.version-matcher//True) ~~ Bool ?? '' !! ":ver<$.version-matcher>",
          ($.auth-matcher   //True) ~~ Bool ?? '' !! ":auth<$.auth-matcher>",
          ($.api-matcher    //True) ~~ Bool ?? '' !! ":api<$.api-matcher>";
    }

    method parse-rep-spec(CompUnit::DependencySpecification:U: Str:D $spec)
        returns CompUnit::DependencySpecification:D
    {
        my %options;
        m/
            $<short>= [ <.ident>+ % '::' ]
            [ ':' $<n>=\w+
                <[ < ( [ { ]> $<v>=<[\w\-.*:]>+ <[ > ) \] } ]>
                { %options{$<n>} = ~$<v> }
            ]*
        /;
        CompUnit::DependencySpecification.new:
            :short-name($<short>)
            :version-matcher(%options<ver> // %options<version>)
            :auth-matcher(%options<auth> // %options<author> // %options<authority>);
    }
}

# vim: ft=perl6 expandtab sw=4
