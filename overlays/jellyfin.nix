# This overlay adds the intro skipper plugin to Jellyfin web interface
final: prev: {
  # Jellyfin intro skipper plugin
  jellyfin-web = prev.jellyfin-web.overrideAttrs (
    finalAttrs: previousAttrs: {
      installPhase = ''
        runHook preInstall
        # Inject the skip-intro-button script into the HTML head
        sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html
        mkdir -p $out/share
        cp -a dist $out/share/jellyfin-web
        runHook postInstall
      '';
    }
  );
}
