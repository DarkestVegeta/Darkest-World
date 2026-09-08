import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function slugify(value: string) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

async function igdbToken() {
  const clientId = Deno.env.get("IGDB_CLIENT_ID");
  const clientSecret = Deno.env.get("IGDB_CLIENT_SECRET");
  if (!clientId || !clientSecret) return null;
  const r = await fetch(`https://id.twitch.tv/oauth2/token?client_id=${encodeURIComponent(clientId)}&client_secret=${encodeURIComponent(clientSecret)}&grant_type=client_credentials`, { method: "POST" });
  if (!r.ok) throw new Error(`IGDB auth failed: ${r.status}`);
  return { clientId, ...(await r.json()) };
}

async function searchIGDB(query: string) {
  const auth = await igdbToken();
  if (!auth) throw new Error("IGDB credentials are not configured");
  const body = `search \\\"${query.replaceAll('"', '\\\\\\\\\"')}\\\"; fields id,name,slug,summary,first_release_date,franchise.name,platforms.name,genres.name,cover.image_id; limit 10;`;
  const r = await fetch("https://api.igdb.com/v4/games", { method: "POST", headers: { "Client-ID": auth.clientId, Authorization: `Bearer ${auth.access_token}`, Accept: "application/json" }, body });
  if (!r.ok) throw new Error(`IGDB request failed: ${r.status}`);
  return await r.json();
}

async function searchTMDB(query: string, type: "movie" | "tv") {
  const token = Deno.env.get("TMDB_ACCESS_TOKEN");
  if (!token) throw new Error("TMDB access token is not configured");
  const endpoint = type === "movie" ? "movie" : "tv";
  const r = await fetch(`https://api.themoviedb.org/3/search/${endpoint}?query=${encodeURIComponent(query)}&include_adult=false&language=en-US&page=1`, { headers: { Authorization: `Bearer ${token}`, Accept: "application/json" } });
  if (!r.ok) throw new Error(`TMDB request failed: ${r.status}`);
  return await r.json();
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    if (req.method !== "POST") return Response.json({ error: "POST required" }, { status: 405, headers: corsHeaders });
    const body = await req.json();
    const source = String(body.source ?? "").trim();
    const query = String(body.query ?? "").trim();
    if (!query) return Response.json({ error: "query required" }, { status: 400, headers: corsHeaders });
    if (!['igdb','tmdb_movie','tmdb_tv'].includes(source)) return Response.json({ error: "source must be igdb, tmdb_movie or tmdb_tv" }, { status: 400, headers: corsHeaders });

    let results: any[] = [];
    if (source === "igdb") {
      const rows = await searchIGDB(query);
      results = rows.map((g: any) => ({
        content_type: "game",
        title: g.name,
        slug: slugify(g.slug || g.name),
        release_date: g.first_release_date ? new Date(g.first_release_date * 1000).toISOString().slice(0,10) : null,
        description: g.summary ?? null,
        franchise: g.franchise?.name ?? null,
        external_source: "igdb",
        external_id: String(g.id),
        image_url: g.cover?.image_id ? `https://images.igdb.com/igdb/image/upload/t_cover_big/${g.cover.image_id}.jpg` : null,
        metadata: g,
      }));
    } else {
      const type = source === "tmdb_movie" ? "movie" : "tv";
      const data = await searchTMDB(query, type);
      results = (data.results ?? []).map((x: any) => ({
        content_type: type === "movie" ? "movie" : "series",
        title: x.title ?? x.name,
        slug: slugify(x.title ?? x.name),
        release_date: (x.release_date ?? x.first_air_date) || null,
        description: x.overview ?? null,
        franchise: null,
        external_source: "tmdb",
        external_id: String(x.id),
        image_url: x.poster_path ? `https://image.tmdb.org/t/p/w500${x.poster_path}` : null,
        metadata: x,
      }));
    }

    // Viewer lookup only. Nothing is written to darkestworld_content.
    return Response.json({ ok: true, source, query, count: results.length, items: results }, { headers: corsHeaders });
  } catch (e) {
    return Response.json({ ok: false, error: e instanceof Error ? e.message : String(e) }, { status: 500, headers: corsHeaders });
  }
});
